namespace :capy do
   desc "Remove temporary capybara web pages"
   task :clean do
     Dir[File.join(RAILS_ROOT, 'capybara-*.html')].each { |file| system "rm #{file}" }
   end
end

