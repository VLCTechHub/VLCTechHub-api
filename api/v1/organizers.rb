# frozen_string_literal: true

require_relative 'entity/organizer'

module VLCTechHub
  module API
    module V1
      class Routes < Grape::API
        version 'v1', using: :path

        resource 'organizers' do
          helpers do
            def organizers
              @organizers ||= VLCTechHub::Organizer::Repository.new
            end
          end

          get do
            result = organizers.find_with_handle
            present :organizers, result.to_a, with: Organizer
          end
        end
      end
    end
  end
end
