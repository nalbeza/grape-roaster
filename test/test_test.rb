require_relative 'test_helper'

class SongVaultApiTest < MiniTest::Test

  def test_all
    res = json_get '/v1/albums'
    pattern = {
      links: {
        'albums.band' => %r'/bands/{albums.band}\Z'
      },
      albums: [
        {
          id: String,
          title: 'Animals',
          links: {
            band: String,
            tracks: [String, String]
          }
        },
        {
          id: String,
          title: 'The Dark Side of the Moon',
          links: {
            band: String,
            tracks: [String, String]
          }
        }
      ],
      linked: {
        bands: [
        ],
        tracks: [
        ]
      }
    }
    assert_equal 200, res.status
    assert_json_match pattern, res.json_body
  end

end
