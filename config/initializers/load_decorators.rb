# frozen_string_literal: true
# Auto-load all *_decorator.rb files in app/decorators on each reload
Rails.configuration.to_prepare do
  Dir.glob(Rails.root.join('app', 'decorators', '**', '*_decorator.rb')).each do |decorator|
    require_dependency(decorator)
  end
  # Apply the Bulkrax exporter and importer decorator
  Bulkrax::ExportersController.prepend(Bulkrax::ExportersControllerDecorator)
  Bulkrax::ImportersController.prepend(Bulkrax::ImportersControllerDecorator)
end
