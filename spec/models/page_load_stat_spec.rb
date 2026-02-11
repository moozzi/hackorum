require 'rails_helper'

RSpec.describe PageLoadStat, type: :model do
  it 'persists a record with all attributes' do
    PageLoadStat.insert({
      url: '/topics/1',
      controller: 'topics',
      action: 'show',
      render_time: 42.5,
      is_turbo: false,
      created_at: Time.current
    })

    stat = PageLoadStat.last
    expect(stat.url).to eq('/topics/1')
    expect(stat.controller).to eq('topics')
    expect(stat.action).to eq('show')
    expect(stat.render_time).to be_within(0.01).of(42.5)
    expect(stat.is_turbo).to eq(false)
    expect(stat.created_at).to be_present
  end

  it 'stores turbo requests' do
    PageLoadStat.insert({
      url: '/topics/1',
      controller: 'topics',
      action: 'show',
      render_time: 15.0,
      is_turbo: true,
      created_at: Time.current
    })

    expect(PageLoadStat.last.is_turbo).to eq(true)
  end
end
