require_relative 'test_helper'

class SongVaultApiTest < MiniTest::Test

  def test_create
    album = {
      albums: {
        title: 'Hatebreeder'
      }
    }
    pattern = {
      albums: {
        id: String,
        title: 'Hatebreeder',
        links: {
          band: nil,
          tracks: []
        }
      }
    }
    res = json_post '/v1/albums', JSON.generate(album)
    assert_equal 201, res.status
    assert_json_match pattern, res.json_body
  end

  def test_delete
    res = json_delete '/v1/albums/1'
    refute Album.exists?(1)
    assert_equal 204, res.status
  end

  def test_create_to_one_relationship
    band = Band.create(name: 'Link and the Old Man')
    rel = {
      bands: band.id.to_s
    }
    res = json_post '/v1/albums/1/links/band', JSON.generate(rel)
    album = Album.find(1)
    assert_equal band.id, album.band_id
    assert_equal 204, res.status
  end

  def test_update_to_one_relationship
    band = Band.create(name: 'Mario and Luigi')
    album = {
      albums: {
        links: {
          band: band.id.to_s
        }
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
          band: band.id.to_s,
          tracks: []
        }
      },
      linked: {
        bands: [{
          id: band.id.to_s,
          name: band.name
        }]
      }
    }
    res = json_put '/v1/albums/1', JSON.generate(album)
    assert_equal 204, res.status
    assert_json_match pattern, res.json_body
  end

  def test_update_to_many_relationship
    tracks = 2.times.map {|i| Track.create(title: "Track #{i}") }
    track_ids = tracks.map(&:id).map(&:to_s)
    album = {
      albums: {
        links: {
          tracks: track_ids
        }
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
          tracks: track_ids
        }
      },
      linked: {
        tracks: [
          {
            id: tracks[0].id,
            title: tracks[0].title
          },
          {
            id: tracks[1].id,
            title: tracks[1].title
          }
        ]
      }
    }
    res = json_put '/v1/albums/1', JSON.generate(album)
    assert_equal 204, res.status
    assert_json_match pattern, res.json_body
  end

  def test_get_to_one_relationship
    pattern = {
      bands: {
        id: String,
        name: 'Pink Floyd'
      }
    }

    res = json_get '/v1/albums/1/links/band'
    assert_json_match pattern, res.json_body
    assert_equal 200, res.status
  end

  def test_create_to_many_relationship
    track = Track.create(title: 'New Track')
    rel = {
      tracks: track.id 
    }
    body = JSON.generate(rel)
    res = json_post '/v1/albums/1/links/tracks', body
    album = Album.find(1)
    track.reload
    expected_tracks = {
      'tracks' => [
        {
          id: String,
          title: 'New Track'
        }.ignore_extra_keys!
      ].ignore_extra_values!
    }
    assert_empty res.body
    assert_equal 204, res.status
  end

  def test_get_to_many_relationship
    pattern = {
      tracks: [
        {
          id: String,
          index: Integer,
          title: 'Dogs'
        },
        {
          id: String,
          index: Integer,
          title: 'Pigs (Three Different Ones)'
        }
      ]
    }
    res = json_get '/v1/albums/1/links/tracks'
    assert_json_match pattern, res.json_body
    assert_equal 200, res.status
  end

  def test_all
    res = json_get '/v1/albums'
    a1 = Album.find(1)
    a2 = Album.find(2)
    pattern = {
      albums: [
        {
          id: a1.id.to_s,
          title: a1.title,
          links: {
            band: a1.band_id.to_s,
            tracks: a1.tracks.map(&:id).map(&:to_s)
          }
        },
        {
          id: a2.id.to_s,
          title: a2.title,
          links: {
            band: a2.band_id.to_s,
            tracks: a2.tracks.map(&:id).map(&:to_s)
          }
        }
      ]
    }
    assert_equal 200, res.status
    assert_json_match pattern, res.json_body
  end

  def test_single
    res = json_get '/v1/albums/1'
    album = Album.find(1)
    pattern = {
      albums: {
        id: album.id.to_s,
        title: album.title,
        links: {
          band: album.band_id.to_s,
          tracks: album.tracks.map(&:id).map(&:to_s)
        }
      }
    }
    assert_equal 200, res.status
    assert_json_match pattern, res.json_body
  end
end
