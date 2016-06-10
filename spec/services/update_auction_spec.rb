require 'rails_helper'

describe UpdateAuction do
  describe '#perform' do
    context 'when changing the title' do
      it 'updates the title' do
        auction = create(:auction, :delivery_due_at_expired)
        new_title = 'The New Title'
        params = { auction: { title: new_title } }

        updater = UpdateAuction.new(auction, params)

        expect { updater.perform }.to change { auction.title }.to(new_title)
      end
    end

    context 'when result is set to accepted' do
      context 'and the auction is below the micropurchase threshold' do
        it 'calls the CreateCapProposalJob' do
          auction = create(:auction,
                           :below_micropurchase_threshold,
                           :winning_vendor_is_small_business,
                           :delivery_due_at_expired)
          allow(CreateCapProposalJob).to receive(:perform_later)
            .with(auction.id)
            .and_return(nil)
          params = { auction: { result: 'accepted' } }

          UpdateAuction.new(auction, params).perform

          expect(CreateCapProposalJob).to have_received(:perform_later).with(auction.id)
        end
      end

      context 'and the auction is between micropurchase and SAT threshold' do
        context 'and the winning vendor is a small business' do
          it 'calls the CreateCapProposalJob' do
            auction = create(
              :auction,
              :between_micropurchase_and_sat_threshold,
              :winning_vendor_is_small_business,
              :delivery_due_at_expired
            )
            allow(CreateCapProposalJob).to receive(:perform_later)
              .with(auction.id)
              .and_return(nil)
            params = { auction: { result: 'accepted' } }

            UpdateAuction.new(auction, params).perform

            expect(CreateCapProposalJob).to have_received(:perform_later).with(auction.id)
          end
        end

        context 'and the winning vendor is not a small business' do
          it 'does not call the CreateCapProposalJob' do
            auction = create(
              :auction,
              :between_micropurchase_and_sat_threshold,
              :winning_vendor_is_non_small_business,
              :delivery_due_at_expired
            )
            allow(CreateCapProposalJob).to receive(:perform_later)
              .with(auction.id)
              .and_return(nil)
            params = { auction: { result: 'accepted' } }

            UpdateAuction.new(auction, params).perform

            expect(CreateCapProposalJob).to_not have_received(:perform_later).with(auction.id)
          end
        end
      end
    end

    context 'when result is set to rejected' do
      it 'does not set cap_proposal_url' do
        auction = create(:auction, :delivery_due_at_expired)
        params = { auction: { result: 'rejected' } }

        updater = UpdateAuction.new(auction, params)

        expect { updater.perform }.to_not change { auction.cap_proposal_url }
        expect(auction.cap_proposal_url).to eq ""
      end

      it 'does not call the CreateCapProposalJob' do
        auction = create(:auction, :delivery_due_at_expired)
        params = { auction: { result: 'rejected' } }
        allow(CreateCapProposalJob).to receive(:perform_later)
          .with(auction.id)
          .and_return(nil)

        UpdateAuction.new(auction, params)

        expect(CreateCapProposalJob).to_not have_received(:perform_later).with(auction.id)
      end
    end
  end
end
