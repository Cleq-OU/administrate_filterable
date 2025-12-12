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

      filter_params = extract_filter_params
      return resources if filter_params.blank?

      # Get date/datetime field names from dashboard
      date_fields = @filterable_attributes.select do |attr|
        attr.is_a?(Administrate::Field::DateTime) || attr.is_a?(Administrate::Field::Date)
      end.map { |attr| attr.attribute.to_s }

      # Build mapping of BelongsTo attribute names to foreign keys
      belongs_to_mapping = {}
      @filterable_attributes.select { |attr| attr.is_a?(Administrate::Field::BelongsTo) }.each do |attr|
        belongs_to_mapping[attr.attribute.to_s] = attr.attribute.to_s.foreign_key
      end

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

        # Map BelongsTo attribute names to foreign keys
        column_name = belongs_to_mapping[key_str] || key_str

        # Regular filters
        next unless resources.column_names.include?(column_name) && value.present?

        column = resources.columns_hash[column_name]

        # Handle array values (from checkboxes)
        if value.is_a?(Array)
          cleaned_values = value.reject(&:blank?)
          resources = resources.where(column_name => cleaned_values) if cleaned_values.any?
        elsif column && column.type == :string
          sanitized_query = ActiveRecord::Base.send(:sanitize_sql_array, ["#{column_name} LIKE ?", "%#{value}%"])
          resources = resources.where(sanitized_query)
        else
          resources = resources.where(column_name => value)
        end
      end

      resources
    end

    private

    def extract_filter_params
      # Get filterable field names
      filterable_field_names = @filterable_attributes.map { |attr| attr.attribute.to_s }

      # Get belongs_to field names and their foreign keys
      belongs_to_fields = @filterable_attributes.select do |attr|
        attr.is_a?(Administrate::Field::BelongsTo)
      end
      belongs_to_foreign_keys = belongs_to_fields.map do |attr|
        attr.attribute.to_s.foreign_key
      end

      # Get date field names (for _from and _to params)
      date_field_names = @filterable_attributes.select do |attr|
        attr.is_a?(Administrate::Field::DateTime) || attr.is_a?(Administrate::Field::Date)
      end.map { |attr| attr.attribute.to_s }

      # Build list of all permitted filter param keys
      # Include both attribute names and foreign keys for belongs_to associations
      permitted_keys = filterable_field_names + belongs_to_foreign_keys + date_field_names.flat_map { |f| ["#{f}_from", "#{f}_to"] }

      # Permit array values for fields (checkboxes) and foreign keys
      permitted_arrays = (filterable_field_names + belongs_to_foreign_keys).map { |f| { f => [] } }

      # Extract and permit filter params
      params.permit(*permitted_keys, *permitted_arrays).to_h
    end
  end
end
