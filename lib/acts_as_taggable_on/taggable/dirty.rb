module ActsAsTaggableOn::Taggable
  module Dirty
    def self.included(base)
      base.extend ActsAsTaggableOn::Taggable::Dirty::ClassMethods

      base.initialize_acts_as_taggable_on_dirty
    end

    module ClassMethods
      def initialize_acts_as_taggable_on_dirty
        tag_types.map(&:to_s).each do |tags_type|
          tag_type         = tags_type.to_s.singularize

          class_eval <<-RUBY, __FILE__, __LINE__ + 1

            def #{tag_type}_list_changed?
              changes.include?("#{tag_type}_list")
            end

            def #{tag_type}_list_was
              #{tag_type}_list_changed? ? changed_attributes["#{tag_type}_list"] : __send__("#{tag_type}_list")
            end

            def #{tag_type}_list_change
              [#{tag_type}_list, __send__('#{tag_type}_list_was')] if #{tag_type}_list_changed?
            end

            def #{tag_type}_list_changes
              [changed_attributes['#{tag_type}_list'], __send__('#{tag_type}_list')] if #{tag_type}_list_changed?
            end

            private
            def attribute_change(attr)
              [changed_attributes[attr], __send__(attr)] if saved_change_to_attribute?(attr)
            end
          RUBY

        end
      end
    end
  end
end
