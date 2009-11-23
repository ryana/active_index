module ActiveIndex
  module Core
     module ClassMethods

       def find_with_index(*args)
        args_dup = args.dup

        case args.first
        when Symbol
          h = args.second
        else
          h = nil
        end

        if h && (h[:index])
          index_option = h.delete(:index)
          args_dup.second.merge!(:from => "`#{table_name}` USE INDEX `#{index_name_for(index_option)}`")
        else
        end

        find_without_index(*args_dup)
      end

      private
      def index_name_for(option)
        case option
#        when Array
#          "index_on_" + option.map(&:to_s).join('_')
#        when Symbol
#          "index_on_#{option}"
        when String
          option
        else
          raise 'Must pass String to index option'
        end
      end

    end
  end
end

ActiveRecord::Base.extend ActiveIndex::Core::ClassMethods
class << ActiveRecord::Base
  alias_method_chain :find, :index
end
