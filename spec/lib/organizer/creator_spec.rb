# frozen_string_literal: true

require 'spec_helper'

describe VLCTechHub::Organizer::Creator do
  subject(:organizer_creator) { described_class.new(twitter_client) }

  let(:twitter_client) { instance_double(::Twitter::REST::Client) }

  let(:fake_twitter_user) do
    instance_double(
      ::Twitter::User,
      name: 'a name', description: 'a description', profile_image_url: 'an url', website?: true, website: 'a website'
    )
  end

  it 'returns the basic profile from twitter' do
    handle = '@a_handle'

    allow(twitter_client).to receive(:user).with(handle).and_return(fake_twitter_user)

    organizer = organizer_creator.create(handle)

    expect(twitter_client).to have_received(:user)

    expect(organizer[:hashtag]).to eq(handle)
    expect(organizer[:name]).to eq(fake_twitter_user.name)
    expect(organizer[:description]).to eq(fake_twitter_user.description)
    expect(organizer[:profile_image_small_url]).to eq(fake_twitter_user.profile_image_url)
    expect(organizer[:profile_image_big_url]).to eq(fake_twitter_user.profile_image_url)
    expect(organizer[:website]).to eq(fake_twitter_user.website)
  end
end
