require 'support/models/color'
require 'support/models/book'

describe 'Model methods' do
  describe '.reindex!' do
    it 'uses the specified scope' do
      TestUtil.reset_colors!

      Color.create!(name: 'red', short_name: 'r3', hex: 3)
      Color.create!(name: 'red', short_name: 'r1', hex: 1)
      Color.create!(name: 'purple', short_name: 'p')

      Color.clear_index!(true)

      Color.where(name: 'red').reindex!(3, true)
      expect(Color.search('').size).to eq(2)

      Color.clear_index!(true)
      Color.where(id: Color.first.id).reindex!(3, true)
      expect(Color.search('').size).to eq(1)
    end
  end

  describe '.without_auto_index' do
    it 'disables auto indexing for the model' do
      TestUtil.reset_colors!

      Color.without_auto_index do
        Color.create!(name: 'blue', short_name: 'b', hex: 0xFF0000)
      end

      expect(Color.search('blue')).to be_empty

      Color.reindex!(2, true)
      expect(Color.search('blue')).to be_one
    end

    it 'does not disable auto indexing for other models' do
      TestUtil.reset_books!

      Color.without_auto_index do
        Book.create!(
          name: 'Frankenstein', author: 'Mary Shelley',
          premium: false, released: true
        )
      end

      expect(Book.search('Frankenstein')).to be_one
    end
  end

  describe '.index_documents' do
    it 'updates existing documents' do
      TestUtil.reset_colors!

      _blue = Color.create!(name: 'blue', short_name: 'blu', hex: 0x0000FF)
      _black = Color.create!(name: 'black', short_name: 'bla', hex: 0x000000)

      json = Color.raw_search('')
      Color.index_documents Color.limit(1), true # reindex last color, `limit` is incompatible with the reindex! method
      expect(json['hits'].count).to eq(Color.raw_search('')['hits'].count)
    end
  end
end
