# frozen_string_literal: true

RSpec.describe Hyrax::FileSetIndexerDecorator, type: :decorator do
  let(:user)           { FactoryBot.create(:user) }
  let(:file_set)       { create(:file_set) }
  let(:relation)       { :original_file }
  let(:actor)          { Hyrax::Actors::FileActor.new(file_set, relation, user) }
  let(:file_path)      { File.join(fixture_path, 'pdf', 'archive.pdf') }
  let(:fixture)        { fixture_file_upload(file_path, 'application/pdf') }
  let(:huf)            { Hyrax::UploadedFile.new(user: user, file_set_uri: file_set.uri, file: fixture) }
  let(:io)             { JobIoWrapper.new(file_set_id: file_set.id, user: user, uploaded_file: huf) }
  let(:solr_document)  { SolrDocument.find(file_set.id) }
  let!(:test_strategy) { Flipflop::FeatureSet.current.test! }

  describe '#generate_solr_document' do
    it 'adds PDF text to solr document when PDF.js' do
      test_strategy.switch!(:default_pdf_viewer, true)
      actor.ingest_file(io)
      # rubocop:disable Metrics/LineLength
      expect(solr_document['all_text_tsimv']).to eq [
        "; ORIGINALITY AUTHENTICITY LEGACY KJ? Kolbe 6? Fanning Numismatic Booksellers ! I GUI; he .-.V Rt Irrericc Library ADA IE S MUNZEm cowrnA MB MONTAGU >DVl> till HA USES AOAMS A ? BENTLEY COINS V1 INGLAN!) A'HIMS AMERICANA CHWARZBUft OK ! .N5T FISCHEfl ofa Nuimsmatu PENNY , SHE LUO; PASCHAL BREEN I Bookseller \fWhether you are looking for recently published books, obscure monographs from years ago, classic auction catalogues, or bibliophilic treasures, Kolbe & Fanning has you covered. OUT-OF-PRINT WORKS Kolbe & Fanning's public auctions and online sales offer thousands of out-ofprint numismatic titles each year include material from all in all We languages and time periods, offering a truly comprehensive resource to furthering your library. In addition, bookstore at our online numislit.com stocks well over 1000 out-of-print numismatic works available for immediate purchase. \froruiA * mum** niMTIiT^ George F. Kolbe is Member No. 23 Life American Numismatic Association, a 1 af 6 of the member since 1987 of the International Association of Professional Numismatists, co-founder of the Numismatic Bibliomania Society, a Fellow of the American Numismatic Society and Royal Numismatic Society, and a member of the Rittenhouse Society and several other organizations. Kolbe Library of a F. the author of The Reference Numismatic Bookseller and numerous on numismatic David is articles literature. Fanning holds a Ph.D. in English Literature from the Ohio State University and has been a student of numismatic literature since childhood. He is Life Member 6230 of the American Numismatic Association and is a Fellow of the American Numismatic Society and the Royal . Numismatic Society. He is a Society and also belongs to member many of the Rittenhouse specialized and regional numismatic organizations. Currently, he serves as a Board member is also a of the Numismatic Bibliomania Society, of which he life literature, member. He has published widely on numismatic North American coins, Islamic coins colonial coins, medals, U.S. federal and other topics. \fNEW PUBLICATIONS On Kolbe you can We & find Fannings online bookstore at numislit.com, new publications routinely import many new domestic on all aspects of numismatics. new books from publications, overseas and carry making special effort to stock works not readily available elsewhere. \fRARITIES Our annual highlight New York Book Auction of the numismatic important offerings of rare With become bibliophiles year; titles, with active participation and other from around the world, the sale frequently generates record prices and brings to the numismatic market significant works rarely seen elsewhere. Kolbe a plated catalogues, special editions, exquisite bindings, delicacies. has Fanning Numismatic Booksellers numislit.com \fKolbe & F anning Numismatic Booksellers 141 W. Johnstown Road (6 4) 1 4 4-0855 1 | Gahanna, Ohio 43230 | (614) 41 4-0860 fax df@numislit.com )HN ULL Builder of the ( Colony ARKE TAlAXSt VtUKJI KGIlESl LUYNES SEP.V) 'MANE \f"
      ]
      # rubocop:enable Metrics/LineLength
    end
  end
end
