class SetStarOptionPlusStarRightPlusStarEditHelp3 < ActiveRecord::Migration
  def self.up 
    User.as(:wagbot) do
      card = Card.fetch_or_new "*options+*right+*edit help", :type=>"Basic"
      if card.revisions.empty? || card.revisions.map(&:author).map(&:login).uniq == ["wagbot"]
        card.content =<<CONTENT
<div>Value options for a set of [[Pointer]] cards. Can itself be a Pointer or a [[Search]]. [[http://wagn.org/Pointer|Learn about setting options on Pointers.]]</div>
CONTENT
        card.permit('edit',Role[:admin])
        card.permit('delete',Role[:admin])
        card.save!
      end
    end
  end

  def self.down
  end
end
