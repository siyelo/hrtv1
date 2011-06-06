Factory.define :model_help, :class => ModelHelp do |f|
  f.model_name  { 'model_name' }
  f.short       { 'short model help' }
  f.long        { 'long model help' }
end
