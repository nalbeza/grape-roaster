require_relative 'test_helper'

class SongVaultApiTest < MiniTest::Test

  def test_create
    album = {
      albums: {
        title: 'Animals'
=begin
        links: {
          band: String
        }
=end
      }
    }
    pattern = {
      links: {
        'albums.band' => %r'/bands/{albums.band}\Z'
      },
      albums: {
        id: String,
        title: 'Animals',
        links: {
          band: nil,
          tracks: []
        }
      },
      linked: {
        bands: [
        ],
        tracks: [
        ]
      }
    }
    res = json_post '/v1/albums/1', JSON.generate(album)
    assert_equal 201, res.status
    assert_json_match pattern, res.json_body
  end

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

  def test_single
    res = json_get '/v1/albums/1'
    pattern = {
      links: {
        'albums.band' => %r'/bands/{albums.band}\Z'
      },
      albums: {
        id: String,
        title: 'Animals',
        links: {
          band: String,
          tracks: [String, String]
        }
      },
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
