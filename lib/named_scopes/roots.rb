# http://tuxicity.se/rails/dry/2009/01/04/share-named-scopes-in-rails.html
module NamedScopes::Roots
  def self.included(base)
    base.class_eval do

      # overrides 'roots' method from awesome_nested_set
      # and returns roots by a code type (which can be nested in other code type)
      named_scope :roots,
                  :joins => "LEFT OUTER JOIN codes AS parents ON codes.parent_id = parents.id",
                  :conditions => ["(codes.type = :t AND parents.type != :t) OR
                                  (codes.parent_id IS NULL and codes.type = :t)", {:t => name}]
    end
  end
end
