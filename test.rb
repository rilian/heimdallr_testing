require 'active_record'
require 'heimdallr'

ActiveRecord::Base.establish_connection({adapter: 'sqlite3', database: 'development.sqlite3'})

# Define a typical set of models.
class User < ActiveRecord::Base
  has_many :articles
end

class Article < ActiveRecord::Base
  include Heimdallr::Model

  belongs_to :owner, :class_name => 'User'

  restrict do |user, record|
    if user.admin?
      # Administrator or owner can do everything
      scope :fetch
      scope :delete
      can [:view, :create, :update]
    else
      # Other users can view only their own or non-classified articles...
      scope :fetch,  -> { where('owner_id = ? or secrecy_level < ?', user.id, 5) }
      scope :delete, -> { where('owner_id = ?', user.id) }

      # ... and see all fields except the actual security level
      # (through owners can see everything)...
      if record.try(:owner) == user
        can :view
        can :update, {
            # each field may have validators that will allow update
            secrecy_level: { inclusion: { in: 0..4 } }
        }
      else
        can    :view
        cannot :view, [:secrecy_level]
      end

      # ... and can create them with certain restrictions.
      can :create, %w(content)
      can :create, {
          # each field may have fixed value that cannot be overridden
          owner_id:      user.id,
          secrecy_level: { inclusion: { in: 0..4 } }
      }
    end
  end
end

# Cleanup
Article.delete_all
User.delete_all

# Create some fictional data.
admin   = User.create admin: true
johndoe = User.create admin: false

Article.create id: 1, owner: admin,   content: "Nothing happens",  secrecy_level: 0
Article.create id: 2, owner: admin,   content: "This is a secret", secrecy_level: 10
Article.create id: 3, owner: johndoe, content: "Hello World"

# Get a restricted scope for the user.
secure = Article.restrict(johndoe)

# Use any ARel methods:
puts secure.pluck(:content)
# => ["Nothing happens", "Hello World"]

# Everything should be permitted explicitly:
begin
  puts secure.first.delete
rescue
  puts 'Heimdallr::PermissionError is raised'
end
# ! Heimdallr::PermissionError is raised

begin
  puts secure.find(1).secrecy_level
rescue
  puts 'Heimdallr::PermissionError is raised'
end
# ! Heimdallr::PermissionError is raised

# There is a helper for views to be easily written:
view_passed = secure.first.implicit
puts view_passed.secrecy_level
# => nil

# If only a single value is possible, it is inferred automatically:
puts secure.create! content: "My second article"
# => Article(id: 4, owner: johndoe, content: "My second article", secrecy_level: 0)

# ... and cannot be changed:
puts secure.create! owner: admin, content: "I'm a haxx0r", secrecy_level: 0
# ! Heimdallr::PermissionError is raised

# You can use any valid ActiveRecord validators, too:
puts secure.create! content: "Top Secret", secrecy_level: 0
# ! ActiveRecord::RecordInvalid is raised

# John Doe would not see what he is not permitted to, ever:
# -- I know that you have this classified material! It's in folder #2.
begin
  puts secure.find 2
rescue
  puts 'ActiveRecord::RecordNotFound is raised'
end
# ! ActiveRecord::RecordNotFound is raised
# -- No, it is not.

# Cleanup again
Article.delete_all
User.delete_all
