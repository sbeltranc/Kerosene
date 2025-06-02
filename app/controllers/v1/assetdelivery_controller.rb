class V1::AssetdeliveryController < ApplicationController
  require 'aws-sdk-s3'
  require 'net/http'
  require 'uri'

  # this doesnt make much sense but literally i dont know where else to put it
  COREGUI_PATH = Rails.root.join('lib', 'CoreGui').to_s

  # GET /v1/asset
  def asset
    asset_id = params[:id]
    version = params[:version] || params[:assetVersionId]
    
    return render json: respond_with_error(1, "Asset ID is required"), status: :bad_request unless asset_id.present?
    return render json: respond_with_error(1, "Invalid Asset ID format"), status: :bad_request unless asset_id.match?(/\A\d{1,10}\z/)

    # is asset a coregui?
    coregui_path = File.join(COREGUI_PATH, asset_id)
    if File.exist?(coregui_path)
      begin
        # if so sign
        script_content = File.read(coregui_path)
        signed_script = Signer.sign(script_content)
        return send_data signed_script, type: 'text/plain', disposition: 'inline'
      rescue => e
        Rails.logger.error "Failed to sign with error: #{e.message}"
        render json: respond_with_error(4, "Failed to sign script"), status: :internal_server_error
        return
      end
    end

    asset = Asset.find_by(id: asset_id)

    if asset&.s3hash.present?
      s3_client = Aws::S3::Client.new

      begin
        response = s3_client.get_object(
          bucket: Rails.configuration.x.aws.bucket,
          key: asset.s3hash
        )
        
        send_data response.body.read, 
          type: 'application/octet-stream', 
          disposition: 'attachment'
      rescue Aws::S3::Errors::ServiceError => e
        Rails.logger.error "R2 Error: #{e.message}"
        render json: respond_with_error(2, "Failed to retrieve asset"), status: :internal_server_error
      end
    else
      base_url = "https://apis.roblox.com/asset-delivery-api/v1/assetId"
      roblox_uri = URI("#{base_url}/#{URI.encode_www_form_component(asset_id)}")
      request = Net::HTTP::Get.new(roblox_uri)
      request['User-Agent'] = 'Roblox/WinInet'
      request['x-api-key'] = 'wIslT5Ffi0uZ5ml1jAL/drUeLybxEVedj1QsjqWveH091GgmZXlKaGJHY2lPaUpTVXpJMU5pSXNJbXRwWkNJNkluTnBaeTB5TURJeExUQTNMVEV6VkRFNE9qVXhPalE1V2lJc0luUjVjQ0k2SWtwWFZDSjkuZXlKaVlYTmxRWEJwUzJWNUlqb2lkMGx6YkZRMVJtWnBNSFZhTlcxc01XcEJUQzlrY2xWbFRIbGllRVZXWldScU1WRnphbkZYZG1WSU1Ea3hSMmR0SWl3aWIzZHVaWEpKWkNJNklqYzVPREU1T0RBeE5USWlMQ0poZFdRaU9pSlNiMkpzYjNoSmJuUmxjbTVoYkNJc0ltbHpjeUk2SWtOc2IzVmtRWFYwYUdWdWRHbGpZWFJwYjI1VFpYSjJhV05sSWl3aVpYaHdJam94TnpRME1UVXdPVGs0TENKcFlYUWlPakUzTkRReE5EY3pPVGdzSW01aVppSTZNVGMwTkRFME56TTVPSDAuYi1kcXFrWFNOMUtpcFZKZVhfTmFXRUh2bzl2MElFZEI4WnlXcGN1ejhncWFaQmhEYUZnWEwtNlBnOHlJQ3k4NWlhOUZfWmdSRXNYQ1VLelE2V0c1bVBndlBOWWlxbmpkYnJ5dEVCV1l4VVVqeHNVSmZ6LU1LQmUydGxTamY4Z0Yzc3VtNVd1bUNoeHBvVDlMS2lHRk5NN2tZZTdqVjlJM0tUNWFGSFZvRFRON0xzZ2EwSUQ4eGcteHZfekhIZGdjLW9jMk0taUxtSUlVZU1vb3lwb21xSGtkdTkwLVdxVVNUbWhBbjdlSWhhWnJ2ZmVKdGhiVTVuYlhsQlRmTmZmMDVFT0lkNElKaGswaHI3enJCTlBZZVhsZXpQMTBhSHlHeUFwcnB6MHFYVjRGVkZiSWpFV2V1bDFmc1htSFFLWTkxYjMtZFhINEJoR0ZEQUpYcUdJZ2h3'

      http = Net::HTTP.new(roblox_uri.host, roblox_uri.port)
      http.use_ssl = true

      begin
        response = http.request(request)
        data = JSON.parse(response.body)

        if data && data['location']
          url = data['location']
          file_hash = URI(url).path.delete_prefix('/')
          query = URI(url).query
          token = "?#{query}"
          expires = URI.decode_www_form(query).to_h['Expires'].to_i * 1000

          if token.present? && expires.present?
            AssetCache.create(
              assetid: asset_id,
              filehash: file_hash,
              assettypeid: data['assetTypeId'],
              token: token,
              expiration: Time.at(expires / 1000)
            )
          end

          redirect_to url, allow_other_host: true, status: :found
        else
          redirect_to "https://assetdelivery.roblox.com/v1/asset/?id=#{asset_id}", 
            allow_other_host: true, 
            status: :found
        end
      rescue StandardError => e
        Rails.logger.error "Roblox API Error: #{e.message}"
        render json: respond_with_error(3, "Failed to retrieve asset from Roblox"), status: :internal_server_error
      end
    end
  end

  # GET /v1/assetId/:assetId
  def assetId
    asset_id = params[:assetId]
    version = params[:version] || params[:assetVersionId]
    
    return render json: respond_with_error(1, "Asset ID is required"), status: :bad_request unless asset_id.present?
    return render json: respond_with_error(1, "Invalid Asset ID format"), status: :bad_request unless asset_id.match?(/\A\d{1,10}\z/)

    # is asset a coregui?
    coregui_path = File.join(COREGUI_PATH, asset_id)
    if File.exist?(coregui_path)
      begin
        # if so sign
        script_content = File.read(coregui_path)
        signed_script = Signer.sign(script_content)
        return send_data signed_script, type: 'text/plain', disposition: 'inline'
      rescue => e
        Rails.logger.error "Failed to sign with error: #{e.message}"
        render json: respond_with_error(4, "Failed to sign script"), status: :internal_server_error
        return
      end
    end

    asset = Asset.find_by(id: asset_id)

    if asset&.s3hash.present?
      s3_client = Aws::S3::Client.new

      begin
        response = s3_client.get_object(
          bucket: Rails.configuration.x.aws.bucket,
          key: asset.s3hash
        )
        
        send_data response.body.read, 
          type: 'application/octet-stream', 
          disposition: 'attachment'
      rescue Aws::S3::Errors::ServiceError => e
        Rails.logger.error "R2 Error: #{e.message}"
        render json: respond_with_error(2, "Failed to retrieve asset"), status: :internal_server_error
      end
    else
      base_url = "https://apis.roblox.com/asset-delivery-api/v1/assetId"
      roblox_uri = URI("#{base_url}/#{URI.encode_www_form_component(asset_id)}")
      request = Net::HTTP::Get.new(roblox_uri)
      request['User-Agent'] = 'Roblox/WinInet'
      request['x-api-key'] = 'wIslT5Ffi0uZ5ml1jAL/drUeLybxEVedj1QsjqWveH091GgmZXlKaGJHY2lPaUpTVXpJMU5pSXNJbXRwWkNJNkluTnBaeTB5TURJeExUQTNMVEV6VkRFNE9qVXhPalE1V2lJc0luUjVjQ0k2SWtwWFZDSjkuZXlKaVlYTmxRWEJwUzJWNUlqb2lkMGx6YkZRMVJtWnBNSFZhTlcxc01XcEJUQzlrY2xWbFRIbGllRVZXWldScU1WRnphbkZYZG1WSU1Ea3hSMmR0SWl3aWIzZHVaWEpKWkNJNklqYzVPREU1T0RBeE5USWlMQ0poZFdRaU9pSlNiMkpzYjNoSmJuUmxjbTVoYkNJc0ltbHpjeUk2SWtOc2IzVmtRWFYwYUdWdWRHbGpZWFJwYjI1VFpYSjJhV05zSWl3aVpYaHdJam94TnpRME1UVXdPVGs0TENKcFlYUWlPakUzTkRReE5EY3pPVGdzSW01aVppSTZNVGMwTkRFME56TTVPSDAuYi1kcXFrWFNOMUtpcFZKZVhfTmFXRUh2bzl2MElFZEI4WnlXcGN1ejhncWFaQmhEYUZnWEwtNlBnOHlJQ3k4NWlhOUZfWmdSRXNYQ1VLelE2V0c1bVBndlBOWWlxbmpkYnJ5dEVCV1l4VVVqeHNVSmZ6LU1LQmUydGxTamY4Z0Yzc3VtNVd1bUNoeHBvVDlMS2lHRk5NN2tZZTdqVjlJM0tUNWFGSFZvRFRON0xzZ2EwSUQ4eGcteHZfekhIZGdjLW9jMk0taUxtSUlVZU1vb3lwb21xSGtkdTkwLVdxVVNUbWhBbjdlSWhhWnJ2ZmVKdGhiVTVuYlhsQlRmTmZmMDVFT0lkNElKaGswaHI3enJCTlBZZVhsZXpQMTBhSHlHeUFwcnB6MHFYVjRGVkZiSWpFV2V1bDFmc1htSFFLWTkxYjMtZFhINEJoR0ZEQUpYcUdJZ2h3'

      http = Net::HTTP.new(roblox_uri.host, roblox_uri.port)
      http.use_ssl = true

      begin
        response = http.request(request)
        data = JSON.parse(response.body)

        if data && data['location']
          url = data['location']
          file_hash = URI(url).path.delete_prefix('/')
          query = URI(url).query
          token = "?#{query}"
          expires = URI.decode_www_form(query).to_h['Expires'].to_i * 1000

          if token.present? && expires.present?
            AssetCache.create(
              assetid: asset_id,
              filehash: file_hash,
              assettypeid: data['assetTypeId'],
              token: token,
              expiration: Time.at(expires / 1000)
            )
          end

          redirect_to url, allow_other_host: true, status: :found
        else
          redirect_to "https://assetdelivery.roblox.com/v1/asset/?id=#{asset_id}", 
            allow_other_host: true, 
            status: :found
        end
      rescue StandardError => e
        Rails.logger.error "Roblox API Error: #{e.message}"
        render json: respond_with_error(3, "Failed to retrieve asset from Roblox"), status: :internal_server_error
      end
    end
  end

  # GET /v1/assetId/:assetId/version/:version
  def assetIdByVersion
    asset_id = params[:assetId]
    version = params[:version]
    
    return render json: respond_with_error(1, "Asset ID is required"), status: :bad_request unless asset_id.present?
    return render json: respond_with_error(1, "Invalid Asset ID format"), status: :bad_request unless asset_id.match?(/\A\d{1,10}\z/)
    return render json: respond_with_error(1, "Version is required"), status: :bad_request unless version.present?
    return render json: respond_with_error(1, "Invalid Version format"), status: :bad_request unless version.match?(/\A\d{1,10}\z/)

    # is asset a coregui?
    coregui_path = File.join(COREGUI_PATH, asset_id)
    if File.exist?(coregui_path)
      begin
        # if so sign
        script_content = File.read(coregui_path)
        signed_script = Signer.sign(script_content)
        return send_data signed_script, type: 'text/plain', disposition: 'inline'
      rescue => e
        Rails.logger.error "Failed to sign with error: #{e.message}"
        render json: respond_with_error(4, "Failed to sign script"), status: :internal_server_error
        return
      end
    end

    asset = Asset.find_by(id: asset_id)

    if asset&.s3hash.present?
      s3_client = Aws::S3::Client.new

      begin
        response = s3_client.get_object(
          bucket: Rails.configuration.x.aws.bucket,
          key: asset.s3hash
        )
        
        send_data response.body.read, 
          type: 'application/octet-stream', 
          disposition: 'attachment'
      rescue Aws::S3::Errors::ServiceError => e
        Rails.logger.error "R2 Error: #{e.message}"
        render json: respond_with_error(2, "Failed to retrieve asset"), status: :internal_server_error
      end
    else
      base_url = "https://apis.roblox.com/asset-delivery-api/v1/assetId"
      roblox_uri = URI("#{base_url}/#{URI.encode_www_form_component(asset_id)}")
      request = Net::HTTP::Get.new(roblox_uri)
      request['User-Agent'] = 'Roblox/WinInet'
      request['x-api-key'] = 'wIslT5Ffi0uZ5ml1jAL/drUeLybxEVedj1QsjqWveH091GgmZXlKaGJHY2lPaUpTVXpJMU5pSXNJbXRwWkNJNkluTnBaeTB5TURJeExUQTNMVEV6VkRFNE9qVXhPalE1V2lJc0luUjVjQ0k2SWtwWFZDSjkuZXlKaVlYTmxRWEJwUzJWNUlqb2lkMGx6YkZRMVJtWnBNSFZhTlcxc01XcEJUQzlrY2xWbFRIbGllRVZXWldScU1WRnphbkZYZG1WSU1Ea3hSMmR0SWl3aWIzZHVaWEpKWkNJNklqYzVPREU1T0RBeE5USWlMQ0poZFdRaU9pSlNiMkpzYjNoSmJuUmxjbTVoYkNJc0ltbHpjeUk2SWtOc2IzVmtRWFYwYUdWdWRHbGpZWFJwYjI1VFpYSjJhV05zSWl3aVpYaHdJam94TnpRME1UVXdPVGs0TENKcFlYUWlPakUzTkRReE5EY3pPVGdzSW01aVppSTZNVGMwTkRFME56TTVPSDAuYi1kcXFrWFNOMUtpcFZKZVhfTmFXRUh2bzl2MElFZEI4WnlXcGN1ejhncWFaQmhEYUZnWEwtNlBnOHlJQ3k4NWlhOUZfWmdSRXNYQ1VLelE2V0c1bVBndlBOWWlxbmpkYnJ5dEVCV1l4VVVqeHNVSmZ6LU1LQmUydGxTamY4Z0Yzc3VtNVd1bUNoeHBvVDlMS2lHRk5NN2tZZTdqVjlJM0tUNWFGSFZvRFRON0xzZ2EwSUQ4eGcteHZfekhIZGdjLW9jMk0taUxtSUlVZU1vb3lwb21xSGtkdTkwLVdxVVNUbWhBbjdlSWhhWnJ2ZmVKdGhiVTVuYlhsQlRmTmZmMDVFT0lkNElKaGswaHI3enJCTlBZZVhsZXpQMTBhSHlHeUFwcnB6MHFYVjRGVkZiSWpFV2V1bDFmc1htSFFLWTkxYjMtZFhINEJoR0ZEQUpYcUdJZ2h3'

      http = Net::HTTP.new(roblox_uri.host, roblox_uri.port)
      http.use_ssl = true

      begin
        response = http.request(request)
        data = JSON.parse(response.body)

        if data && data['location']
          url = data['location']
          file_hash = URI(url).path.delete_prefix('/')
          query = URI(url).query
          token = "?#{query}"
          expires = URI.decode_www_form(query).to_h['Expires'].to_i * 1000

          if token.present? && expires.present?
            AssetCache.create(
              assetid: asset_id,
              filehash: file_hash,
              assettypeid: data['assetTypeId'],
              token: token,
              expiration: Time.at(expires / 1000)
            )
          end

          redirect_to url, allow_other_host: true, status: :found
        else
          redirect_to "https://assetdelivery.roblox.com/v1/asset/?id=#{asset_id}&version=#{version}", 
            allow_other_host: true, 
            status: :found
        end
      rescue StandardError => e
        Rails.logger.error "Roblox API Error: #{e.message}"
        render json: respond_with_error(3, "Failed to retrieve asset from Roblox"), status: :internal_server_error
      end
    end
  end

  # GET /v1/marAssetHash/:marAssetHash/marCheckSum/:marCheckSum
  def assetByMar
    render json: {}
  end

  # POST /v1/assets/batch
  def batch
    render json: {}
  end
end
