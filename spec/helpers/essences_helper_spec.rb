require 'spec_helper'

describe Alchemy::EssencesHelper do
  let(:element) { build_stubbed(:element) }
  let(:content) { build_stubbed(:content, element: element, ingredient: 'hello!') }
  let(:essence) { mock_model('EssenceText', link: nil, partial_name: 'essence_text', ingredient: 'hello!')}

  before do
    allow_message_expectations_on_nil
    content.stub(:essence).and_return(essence)
  end

  describe 'render_essence' do
    subject { render_essence(content) }

    it "renders an essence view partial" do
      should have_content 'hello!'
    end

    context 'with editor given as view part' do
      subject { helper.render_essence(content, :editor) }

      before do
        helper.stub(:label_and_remove_link)
        content.stub(:settings).and_return({})
      end

      it "renders an essence editor partial" do
        content.should_receive(:form_field_name)
        should have_selector 'input[type="text"]'
      end
    end

    context 'if content is nil' do
      let(:content) { nil }

      it "returns empty string" do
        should == ''
      end

      context 'editor given as part' do
        subject { helper.render_essence(content, :editor) }
        before { helper.stub(_t: '') }

        it "displays warning" do
          helper.should_receive(:warning).and_return('')
          should == ''
        end
      end
    end

    context 'if essence is nil' do
      let(:essence) { nil }

      it "returns empty string" do
        should == ''
      end

      context 'editor given as part' do
        subject { helper.render_essence(content, :editor) }
        before { helper.stub(_t: '') }

        it "displays warning" do
          helper.should_receive(:warning).and_return('')
          should == ''
        end
      end
    end
  end

  describe 'render_essence_view' do
    it "renders an essence view partial" do
      render_essence_view(content).should have_content 'hello!'
    end
  end

  describe "render_essence_view_by_name" do
    it "renders an essence view partial by content name" do
      element.should_receive(:content_by_name).and_return(content)
      render_essence_view_by_name(element, 'intro').should have_content 'hello!'
    end
  end

  describe 'value_from_settings_or_options' do
    subject { value_from_settings_or_options(content, options, key) }

    let(:key) { :key }

    context 'with content having settings' do
      let(:content) { double(settings: {key: 'content_settings_value'}) }

      context 'and empty options' do
        let(:options) { {} }

        it "returns the value for key from content settings" do
          expect(subject).to eq('content_settings_value')
        end
      end

      context 'but same key present in options' do
        let(:options) { {key: 'options_value'} }

        it "returns the value for key from options" do
          expect(subject).to eq('options_value')
        end
      end
    end

    context 'with content having no settings' do
      let(:content) { double(settings: {}) }

      context 'and empty options' do
        let(:options) { {} }

        it { expect(subject).to eq(nil) }
      end

      context 'but key present in options' do
        let(:options) { {key: 'options_value'} }

        it "returns the value for key from options" do
          expect(subject).to eq('options_value')
        end
      end
    end

    context 'with content having settings with string as key' do
      let(:content) { double(settings: {'key' => 'value_from_string_key'}) }
      let(:options) { {} }

      it "returns value" do
        expect(subject).to eq('value_from_string_key')
      end
    end

    context 'with key passed as string' do
      let(:content) { double(settings: {key: 'value_from_symbol_key'}) }
      let(:key)     { 'key' }
      let(:options) { {} }

      it "returns value" do
        expect(subject).to eq('value_from_symbol_key')
      end
    end
  end
end
