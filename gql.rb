# Implementing the code from this blog:
# http://mgiroux.me/2015/getting-started-with-rails-graphql-relay/

require 'active_record'
require 'logger'

ActiveRecord::Base.establish_connection adapter: 'sqlite3', database: ':memory:'
ActiveRecord::Base.logger = Logger.new $stdout
ActiveSupport::LogSubscriber.colorize_logging = false

ActiveRecord::Schema.define do
  self.verbose = false

  create_table :blogs do |t|
    t.string :title
    t.string :content
    t.integer :author_id
  end
  
  create_table :authors do |t|
    t.string :name
  end
end

class Blog < ActiveRecord::Base
  belongs_to :author
end

class Author < ActiveRecord::Base
  has_many :blogs
end


Author.create! name: 'Josh' do |author|
  author.blogs.build title: 'Things I think', content: 'not that much, really!'
  author.blogs.build title: 'Good drinks', content: 'Whiskey Coke'
end



require 'GraphQL'

AuthorType = GraphQL::ObjectType.define do
  name "Author"
  description "Author of Blogs"
  field :name, types.String
end

BlogType = GraphQL::ObjectType.define do
  name "Blog"
  description "A Blog"
  field :title, types.String
  field :content, types.String
  field :author do
    type AuthorType
    resolve -> (obj, args, ctx) {
      obj.author
    }
  end
end

QueryType = GraphQL::ObjectType.define do
  name "Query"
  description "The query root for this schema"

  field :blog do
    type BlogType
    argument :id, !types.ID
    resolve -> (obj, args, ctx) {
      Blog.find(args[:id])
    }
  end
end

BlogSchema = GraphQL::Schema.define do
  query QueryType
end

BlogSchema.execute(<<GraphQL, variables: {})
  {blog(id: 1) { title content }}
GraphQL
# => {"data"=>
#      {"blog"=>
#        {"title"=>"Things I think", "content"=>"not that much, really!"}}}

# >> D, [2016-11-09T18:39:22.620053 #50562] DEBUG -- :    (2.4ms)  CREATE TABLE "blogs" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "title" varchar, "content" varchar, "author_id" integer)
# >> D, [2016-11-09T18:39:22.621126 #50562] DEBUG -- :    (0.2ms)  CREATE TABLE "authors" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "name" varchar)
# >> D, [2016-11-09T18:39:22.657939 #50562] DEBUG -- :    (0.2ms)  CREATE TABLE "ar_internal_metadata" ("key" varchar NOT NULL PRIMARY KEY, "value" varchar, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL)
# >> D, [2016-11-09T18:39:22.674209 #50562] DEBUG -- :   ActiveRecord::InternalMetadata Load (0.2ms)  SELECT  "ar_internal_metadata".* FROM "ar_internal_metadata" WHERE "ar_internal_metadata"."key" = ? LIMIT ?  [["key", :environment], ["LIMIT", 1]]
# >> D, [2016-11-09T18:39:22.679812 #50562] DEBUG -- :    (0.1ms)  begin transaction
# >> D, [2016-11-09T18:39:22.681376 #50562] DEBUG -- :   SQL (0.2ms)  INSERT INTO "ar_internal_metadata" ("key", "value", "created_at", "updated_at") VALUES (?, ?, ?, ?)  [["key", "environment"], ["value", "default_env"], ["created_at", 2016-11-10 00:39:22 UTC], ["updated_at", 2016-11-10 00:39:22 UTC]]
# >> D, [2016-11-09T18:39:22.681750 #50562] DEBUG -- :    (0.1ms)  commit transaction
# >> D, [2016-11-09T18:39:22.714957 #50562] DEBUG -- :    (0.1ms)  begin transaction
# >> D, [2016-11-09T18:39:22.716590 #50562] DEBUG -- :   SQL (0.1ms)  INSERT INTO "authors" ("name") VALUES (?)  [["name", "Josh"]]
# >> D, [2016-11-09T18:39:22.717525 #50562] DEBUG -- :   SQL (0.1ms)  INSERT INTO "blogs" ("title", "content", "author_id") VALUES (?, ?, ?)  [["title", "Things I think"], ["content", "not that much, really!"], ["author_id", 1]]
# >> D, [2016-11-09T18:39:22.718255 #50562] DEBUG -- :   SQL (0.1ms)  INSERT INTO "blogs" ("title", "content", "author_id") VALUES (?, ?, ?)  [["title", "Good drinks"], ["content", "Whiskey Coke"], ["author_id", 1]]
# >> D, [2016-11-09T18:39:22.718491 #50562] DEBUG -- :    (0.1ms)  commit transaction
# >> D, [2016-11-09T18:39:22.969418 #50562] DEBUG -- :   Blog Load (0.1ms)  SELECT  "blogs".* FROM "blogs" WHERE "blogs"."id" = ? LIMIT ?  [["id", 1], ["LIMIT", 1]]