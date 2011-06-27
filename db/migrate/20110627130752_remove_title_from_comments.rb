class RemoveTitleFromComments < ActiveRecord::Migration
  def self.up
    Comment.all.each do |comment|
      if comment.title.present?
        comment.comment = comment.title.to_s + "\n\n" + comment.comment.to_s
      end
      comment.save(false)
    end

    remove_column :comments, :title
  end

  def self.down
    add_column :comments, :title, :string
  end
end
