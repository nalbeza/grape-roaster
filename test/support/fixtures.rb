# Pink Floyd !
b = Band.create!(name: 'Pink Floyd')

album = Album.create!(title: 'Animals', band: b)
album.tracks << Track.create!(title: 'Dogs', index: 1)
album.tracks << Track.create!(title: 'Pigs (Three Different Ones)', index: 2)

album = Album.create!(title: 'The Dark Side of the Moon', band: b)
album.tracks << Track.create!(title: 'Speak to Me / Breathe', index: 0)
album.tracks << Track.create!(title: 'On the Run', index: 1)
