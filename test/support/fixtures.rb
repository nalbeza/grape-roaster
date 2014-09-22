b = Band.create!(name: 'The Fugees')
album = Album.create!(title: 'The Score', band: b)
album.tracks << Track.create!(title: 'Ready or Not', index: 0)
album.tracks << Track.create!(title: 'Killing Me Softly', index: 1)
