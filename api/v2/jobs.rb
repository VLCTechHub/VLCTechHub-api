# frozen_string_literal: true

require 'securerandom'

require_relative 'entity/job'

module VLCTechHub
  module API
    module V2
      class Routes < Grape::API
        version 'v2', using: :path

        resource 'jobs' do
          helpers do
            def jobs
              @jobs ||= VLCTechHub::Jobs.new
            end
          end

          desc 'Retrieve job offers published in the last month'
          get do
            result = jobs.find_latest_jobs
            present result.to_a, with: Job
          end

          desc 'Create a new job offer'
          params do
            requires :title, type: String, allow_blank: false, desc: 'The job offer headline'
            requires :description, type: String, allow_blank: false, desc: 'The job offer description'
            optional :link, type: String, desc: 'The link to the published post outside VLCTechHub'
            requires :contact_email, type: String, allow_blank: false, desc: 'The contact email of the job offer poster'
            requires :company, type: Hash, desc: 'The data of the company posting the job offer' do
              requires :name, type: String, allow_blank: false, desc: 'Company name'
              requires :link, type: String, allow_blank: false, desc: 'Company web site'
              optional :twitter, type: String, desc: 'Company twitter handle'
            end
            requires :tags, type: Array, allow_blank: false, desc: 'The tags to categorize the job offer'
            requires :how_to_apply,
                     type: String, allow_blank: false, desc: 'Description of the steps to apply to the job offer'
            requires :salary, type: String, allow_blank: false, desc: 'The job offer salary'
          end
          post do
            created_job = jobs.insert(declared(params))
            VLCTechHub::Job::Mailer.approve(created_job)
            present created_job, with: Job
          end

          desc 'Approve publication from the link in the approval email'
          params do
            requires :uuid,
                     type: String,
                     regexp: /^[0-9A-F]{8}-[0-9A-F]{4}-4[0-9A-F]{3}-[89AB][0-9A-F]{3}-[0-9A-F]{12}$/i,
                     desc: 'The publish id for the job offer'
          end
          get 'approve/:uuid' do
            was_approved = jobs.publish(params[:uuid])

            error!('404 Not found', 404) unless was_approved

            approved_job = jobs.find_by_uuid(params[:uuid])
            present approved_job, with: Job
          end

          desc 'Unlist a published job offer'
          params do
            requires :uuid,
                     type: String,
                     regexp: /^[0-9A-F]{8}-[0-9A-F]{4}-4[0-9A-F]{3}-[89AB][0-9A-F]{3}-[0-9A-F]{12}$/i,
                     desc: 'The publish id for the job offer'
            requires :secret,
                     type: String,
                     regexp: /^[0-9A-F]{8}-[0-9A-F]{4}-4[0-9A-F]{3}-[89AB][0-9A-F]{3}-[0-9A-F]{12}$/i,
                     desc: 'The publisher secret reported to the job poster'
          end
          get 'unlist/:uuid/secret/:secret' do
            was_unpublished = jobs.unpublish(params[:uuid], params[:secret])
            error!('404 Not found', 404) unless was_unpublished

            { status: 'Job offer successfully unpublished.' }
          end
        end
      end
    end
  end
end
