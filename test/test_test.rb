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
    assert_equal band.id.to_s, album.band_id
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
        title: 'Pink Floyd'
      }
    }

    res = json_get '/v1/albums/1/links/band'
    assert_equal 200, res.status
    assert_json_match pattern, res.json_body
  end

  def test_create_to_many_relationship
    tracks = 2.times.map {|i| Track.create(title: "Track #{i}") }
    track_ids = tracks.map(&:id).map(&:to_s)
    rel = {
      tracks: track_ids 
    }
    res = json_post '/v1/albums/1/links/tracks', JSON.generate(rel)
    album = Album.find(1)
    tracks.map(&:reload)
    assert_equal tracks[0], album.tracks[0]
    assert_equal tracks[1], album.tracks[1]
    assert_equal 204, res.status
  end

  def test_get_to_many_relationship
    pattern = {
      tracks: [
        {
          id: String,
          index: 1,
          title: 'Dogs'
        },
        {
          id: String,
          index: 2,
          title: 'Pigs (Three Different Ones)'
        }
      ]
    }

    res = json_get '/v1/albums/1/links/tracks'
    assert_equal 200, res.status
    assert_json_match pattern, res.json_body
  end

  def test_all
    res = json_get '/v1/albums'
    a1 = Album.find(1)
    a2 = Album.find(2)
    pattern = {
      links: {
        'albums.band' => %r'/bands/{albums.band}\Z',
        'albums.tracks' => %r'/bands/{albums.tracks}\Z'
      },
      albums: [
        {
          id: a1.id,
          title: a1.title,
          links: {
            band: a1.band_id.to_s,
            tracks: a1.tracks.map(&:id).map(&:to_s)
          }
        },
        {
          id: a2.id,
          title: a2.title,
          links: {
            band: a2.band_id.to_s,
            tracks: a2.tracks.map(&:id).map(&:to_s)
          }
        }
      ],
      linked: {
        bands: Band.all.map(&:as_json),
        tracks: Track.all.map(&:as_json)
      }
    }
    assert_equal 200, res.status
    assert_json_match pattern, res.json_body
  end

  def test_single
    res = json_get '/v1/albums/1'
    album = Album.find(1)
    pattern = {
      links: {
        'albums.band' => %r'/bands/{albums.band}\Z'
      },
      albums: {
        id: album.id,
        title: album.title,
        links: {
          band: album.band_id.to_s,
          tracks: album.tracks.map(&:id).map(&:to_s)
        }
      },
      linked: {
        bands: [album.band.as_json],
        tracks: album.tracks.map(&:as_json)
      }
    }
    assert_equal 200, res.status
    assert_json_match pattern, res.json_body
  end
end
