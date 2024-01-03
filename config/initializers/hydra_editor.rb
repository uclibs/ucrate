# frozen_string_literal: true
# Adds hydra-editor inputs to the load path
hydra_editor_inputs_path = Gem.loaded_specs['hydra-editor'].full_gem_path + '/app/inputs'
$LOAD_PATH.unshift(hydra_editor_inputs_path) unless $LOAD_PATH.include?(hydra_editor_inputs_path)

# Require the multi_value_input file from hydra-editor
# This is needed because multi_value_input is not a basic SimpleForm input
# and it is used in multiple places both in hyrax and in hydra-editor.
require 'multi_value_input'
