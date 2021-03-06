
module RedmineGroupIssue::Patches
  module QueryPatch
    def self.included(base) # :nodoc:
      base.send(:include, InstanceMethods)

      base.class_eval do
        alias_method_chain :joins_for_order_statement, :group
      end
    end

    module InstanceMethods

      def joins_for_order_statement_with_group(order_options)
        joins = []

        if order_options
          Array.wrap(order_options).map{|c| c.scan(/cf_\d+/)}.flatten.uniq.each do |name|
            column = available_columns.detect {|c| c.name.to_s == name}
            join = column && column.custom_field.join_for_order_statement
            if join
              joins << join
            end
          end
        end

        joins.any? ? joins.join(' ') : nil
      end


    end
  end
end

unless Query.included_modules.include?( RedmineGroupIssue::Patches::QueryPatch)
  Query.send(:include,  RedmineGroupIssue::Patches::QueryPatch)
end