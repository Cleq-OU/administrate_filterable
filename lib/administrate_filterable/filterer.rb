module AdministrateFilterable
  module Filterer
    extend ActiveSupport::Concern

    included do
      filterable
    end

    class_methods do
      def filterable
        # TODO: Figure out a better way to implement the filter functionality
        # I don't think overriding `scoped_resource` is the ideal solution to implement the filter functionality.
        # Because when the Administrate controller is generated, it includes suggestion for overriding `scoped_resource`.
        # I already tried to override Administrate `filter_resources` method, but it doesn't work as expected.
        # So, let's stick with this solution for now. Suggestions are very welcomed!
        define_method(:scoped_resource) do
          resources = resource_class.default_scoped
          filtered_resources(resources)
        end
      end
    end

    def filtered_resources(resources)
      @filterable_attributes = AdministrateFilterable::FiltererService.filter_attributes(dashboard, new_resource)

      # Get filterable field names
      filterable_field_names = @filterable_attributes.map { |attr| attr.attribute.to_s }

      # Get date field names (for _from and _to params)
      date_field_names = @filterable_attributes.select do |attr|
        attr.is_a?(Administrate::Field::DateTime) || attr.is_a?(Administrate::Field::Date)
      end.map { |attr| attr.attribute.to_s }

      # Extract only filter-related params (ignore page, order, controller, action, etc.)
      filter_params = params.slice(*filterable_field_names)

      # Add date range params
      date_field_names.each do |field|
        filter_params["#{field}_from"] = params["#{field}_from"] if params["#{field}_from"].present?
        filter_params["#{field}_to"] = params["#{field}_to"] if params["#{field}_to"].present?
      end

      return resources if filter_params.blank?

      # Get date/datetime field names from dashboard
      date_fields = @filterable_attributes.select do |attr|
        attr.is_a?(Administrate::Field::DateTime) || attr.is_a?(Administrate::Field::Date)
      end.map { |attr| attr.attribute.to_s }

      # Process date range filters first
      date_fields.each do |field|
        from_val = filter_params["#{field}_from"]
        to_val = filter_params["#{field}_to"]

        resources = resources.where("#{field} >= ?", from_val) if from_val.present?
        resources = resources.where("#{field} <= ?", to_val) if to_val.present?
      end

      # Process regular filters (excluding date range params)
      filter_params.each do |key, value|
        key_str = key.to_s

        # Skip date range params (already processed)
        next if date_fields.any? { |field| key_str == "#{field}_from" || key_str == "#{field}_to" }

        # Regular filters
        next unless resources.column_names.include?(key_str) && value.present?

        column = resources.columns_hash[key_str]

        # Handle array values (from checkboxes)
        if value.is_a?(Array)
          cleaned_values = value.reject(&:blank?)
          resources = resources.where(key => cleaned_values) if cleaned_values.any?
        elsif column && column.type == :string
          sanitized_query = ActiveRecord::Base.send(:sanitize_sql_array, ["#{key_str} LIKE ?", "%#{value}%"])
          resources = resources.where(sanitized_query)
        else
          resources = resources.where(key => value)
        end
      end

      resources
    end
  end
end
