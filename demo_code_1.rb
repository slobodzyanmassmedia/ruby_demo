# Accounts listener class
class AccountListener

  # Listen account to updates
  def account_update(account)
    # Send confirmation mail when email is changed or account not confirmed
    if (account.email_changed? || account.confirmed_at_changed?) && !account.confirmed?
      account.send_confirmation_instructions
    end
  end
end


# Service class to work with clients
class Crm::GetClientsService

  def initialize
    # Create dropbox client instance
    @dropbox = DropboxClientService.new(Rails.configuration.dropbox_token)
  end

  # Return clients from CRM system using search term and limit
  def get_clients(term:, limit:)
    @clients = Crm::Client.starts_with(term).per(limit)
    people = []
    @clients.map do |client|
      if client.f_dropboxlink
        files = @dropbox.metadata_link client.f_dropboxlink

        # Generate people list. Make new thread for each get image request
        threads = []
        files['contents'].map do |file|
          if file['mime_type'] == 'image/jpeg'
            threads << Thread.new(file) do |t_file|
              Thread.current[:person] = {
                  name: get_name_from_file_name(t_file['path']),
                  image: get_dropbox_image_link(client.f_dropboxlink, t_file['path'])
              }
            end
          end
        end
        people = threads.map { |t| t.join; t[:person] }
      end
      client = client.attributes
      client[:people] = people
      client
    end
  end

  protected

  # Return person name created from image file name
  def get_name_from_file_name(file)
    file.sub!('/', '').sub!('.jpg', '').gsub!(/[-_]/, ' ').split.map(&:capitalize).join ' '
  end

  # Return image link
  def get_dropbox_image_link(link, path)
    image = @dropbox.metadata_link(link, path)
    uri = URI.parse(image['link'])
    uri.query = 'raw=1'
    uri.to_s
  end
end
