# Rake tasks for generating model / controller diagrams
# http://railroad.rubyforge.org/
#
# Installation:
# gem install railroad
# sudo apt-get install graphviz
#
# Usage:
# rake doc:diagram:models # generate diagram for models
# * you will have to remove reports folder from models because of some naming issues

namespace :doc do
  namespace :diagram do
    task :models do
      sh "railroad -i -l -a -m -M | dot -Tsvg | sed 's/font-size:14.00/font-size:11.00/g' > doc/models.svg"
    end

    task :controllers do
      sh "railroad -i -l -C | neato -Tsvg | sed 's/font-size:14.00/font-size:11.00/g' > doc/controllers.svg"
    end
  end

  task :diagrams => %w(diagram:models diagram:controllers)
end
