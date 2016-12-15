rails g model blog title content author_id:integer
rails g model author name 

class Author < ApplicationRecord
  has_one :blog
end


class Blog < ApplicationRecord
  belongs_to :author
end

gem 'graphql'

- Define some types
- Connect them to a schema
- Execute queries with your schema

Create query_type.rb in app/graph/types folder.

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

author_type.rb:

AuthorType = GraphQL::ObjectType.define do
  name "Author"
  description "Author of Blogs"
  field :name, types.String
end

blog_type.rb:
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

rails g controller queries create

Rails.application.routes.draw do
  resources :queries, via: [:post, :options]
end

rails db:create

author = Author.create(name: 'Daffy')
author.blog = Blog.create(title: 'Get Rick Quick', content: 'Life is short')

a2 = Author.create(name: 'Bugs')
a2.blog = Blog.create(title: 'Do what you love', content: 'Life is too short')


rails db:seed

curl -XPOST -d 'query={ blog(id: 1) { title content author { name }}}' http://localhost:3002/queries
curl -XPOST -d 'query={ blog(id: 1) { title content }}' http://localhost:3002/queries
 
References
http://mgiroux.me/2015/getting-started-with-rails-graphql-relay/
https://rmosolgo.github.io/graphql-ruby
https://gist.github.com/JoshCheek/0a6977d2b40b9d4d5d09615e16a8a656