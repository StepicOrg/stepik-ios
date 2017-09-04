module Fastlane
  module Actions
    class CustomizeScreenshotsAction < Action
      def self.run(params)
        Dir.chdir('fastlane/scripts') do
          UI.message "Download generator..."
          sh 'rm -rf screenshots-frames'
          sh 'git clone https://github.com/kvld/screenshots-frames screenshots-frames'

          Dir.chdir('screenshots-frames') do
            UI.message "Install dependencies..."
            sh 'pip3 install -r requirements.txt'

            UI.message "Working directory: #{params[:path]}"
            sh "python3 process.py '#{params[:path]}'"
          end
        end
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Add caption and device frame to screenshots"
      end

      def self.details
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :path,
                                       env_name: "FL_CUSTOMIZE_SCREENSHOTS_PATH", 
                                       description: "Screenshots root directory", 
                                       verify_block: proc do |value|
                                          UI.user_error!("No screenshots directory passed, pass it using `path: '.'`") unless (value and not value.empty?)
                                       end),
        ]
      end

      def self.output
      end

      def self.return_value
      end

      def self.authors
        ["kvld"]
      end

      def self.is_supported?(platform)
        platform == :ios
      end
    end
  end
end
