# frozen_string_literal: true
class CollectionLoader
  include ActionDispatch::TestProcess

  NON_REPEATABLE_ATTRIBUTES = %i[
    visibility collection_type_gid license
  ].freeze

  REPEATABLE_ATTRIBUTES = %i[
    title creator
  ].freeze

  TEXT_ATTRIBUTES = %i[
    description
  ].freeze

  attr_accessor :collection, :user, :attributes_hash

  def initialize(attributes_hash)
    @user             = User.find_by_email attributes_hash.delete(:submitter_email)
    @attributes_hash  = attributes_parser  attributes_hash
    @collection       = Collection.new     self.attributes_hash
  end

  def create
    collection.apply_depositor_metadata(user.user_key)
    collection.save
    true
  end

  private

    def attributes_parser(attributes_hash)
      attributes = {}
      attributes_hash.keys.each do |a|
        next unless Collection.new.respond_to? a
        value = attributes_hash[a]

        if NON_REPEATABLE_ATTRIBUTES.include? a
          if value.class == Array
            raise "Repeated value passed for non-repeatable attribute"
          else
            attributes[a] = value
          end
        end

        if REPEATABLE_ATTRIBUTES.include? a
          attributes[a] = if value.class == Array
                            value
                          else
                            [value]
                          end
        end

        next unless TEXT_ATTRIBUTES.include? a
        attributes[a] = if value.class == Array
                          [value.join("\n")]
                        else
                          [value]
                        end
      end

      collection_pid = attributes_hash.delete(:pid)
      attributes[:id] = collection_pid unless collection_pid.nil?
      attributes
    end
end
