def pbCheckForUpdates
  # Load local configuration
  local_config_path = File.join("Updater", "config.ini")
  updater = File.join("Updater", "Updater.exe")
  unless File.exist?(local_config_path)
    pbMessage(_INTL("Local configuration file 'config.ini' not found in 'Updater' folder."))
    return
  end

  # Initialize versions
  local_version = nil
  remote_version = nil

  # Step 1: Read local configuration
  File.foreach(local_config_path) do |line|
    line = line.strip
    next if line.empty? || line.start_with?("#") # Skip empty lines or comments

    if line.start_with?("current_version")
      local_version = line[18..-1].to_f
      # puts "local_version: #{local_version}"
    end

    if line.start_with?("url")
      remote_url = line[6..-1]
      # puts "remote URL: #{remote_url}"

      # Step 2: Fetch remote content and process remote version
      remote_text = pbDownloadToString(remote_url)
      if remote_text
        lines = remote_text.split("\n")
        lines.each do |remote_line|
          if remote_line.start_with?("current_version")
            remote_version = remote_line[18..-1].to_f
            # puts "remote_version: #{remote_version}"
          end
        end
      else
        pbMessage("Unable to fetch remote content.")
        # puts "Error: Unable to fetch remote content."
      end
    end
  end

  # Step 3: Compare versions only after both are fetched
  if local_version && remote_version
    if remote_version > local_version
      if pbConfirmMessage("An update is available. Would you like to update?")
        Process.spawn(updater)
        exit
      end
      # puts "Update is available."
    else
      pbMessage("No updates available.")
      # puts "No updates available."
    end
  else
    pbMessage("Unable to compare versions.")
    # puts "Error: Unable to compare versions (local_version or remote_version is nil)."
  end
end
