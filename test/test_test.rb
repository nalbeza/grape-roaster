require_relative 'test_helper'

class SongVaultApiTest < MiniTest::Test

  def test_wut
    res = get '/v1/albums'
    ap JSON.parse(res.body)
  end

end
