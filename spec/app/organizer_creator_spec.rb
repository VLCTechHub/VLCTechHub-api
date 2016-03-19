require 'spec_helper'


describe VLCTechHub::OrganizerCreator do
  let(:fake_twitter_user) do
    double(:fake_twitter_user,
      name: 'a name',
      description: 'a description',
      profile_image_url: 'an url',
      website?: true,
      website: 'a website')
  end

  it 'returns the basic profile from twitter' do

    handle = '@a_handle'

    twitter_client = double(:twitter_client)
    expect(twitter_client).to receive(:user)
        .with(handle).and_return(fake_twitter_user)

    subject = described_class.new(twitter_client)
    organizer = subject.create(handle)

    expect(organizer[:hashtag]).to eq(handle)
    expect(organizer[:name]).to eq(fake_twitter_user.name)
    expect(organizer[:description]).to eq(fake_twitter_user.description)
    expect(organizer[:profile_image_small_url]).to eq(fake_twitter_user.profile_image_url)
    expect(organizer[:profile_image_big_url]).to eq(fake_twitter_user.profile_image_url)
    expect(organizer[:website]).to eq(fake_twitter_user.website)
  end
end
