# -*- coding:binary -*-
require 'spec_helper'

require 'rex/proto/kerberos'
require 'msf/kerberos/client'

describe Msf::Kerberos::Client::Pac do
  subject do
    mod = ::Msf::Exploit.new
    mod.extend ::Msf::Kerberos::Client
    mod.send(:initialize)
    mod
  end

  let(:pac_opts) do
    {
      :client_name => 'test',
      :user_id => 1001,
      :group_id => 513,
      :group_ids => [513, 508],
      :realm => 'DOMAIN',
      :domain_id => 'S-1-5-21-1755879683-3641577184-3486455962',
      :logon_time => Time.utc(2014),
      :checksum_type => Rex::Proto::Kerberos::Crypto::RSA_MD5
    }
  end

  describe "#build_pac" do
    context "when no opts" do
      it "creates a Rex::Proto::Kerberos::Pac::Type" do
        expect(subject.build_pac).to be_a(Rex::Proto::Kerberos::Pac::Type)
      end

      it "creates a PAC-TYPE with default checksum type" do
        pac = subject.build_pac
        expect(pac.checksum).to eq(Rex::Proto::Kerberos::Crypto::RSA_MD5)
      end

      it "creates a PAC-TYPE with default data in buffers" do
        pac = subject.build_pac
        expect(pac.buffers[0].effective_name).to eq('')
      end
    end

    context "when opts" do
      it "creates a Rex::Proto::Kerberos::Pac::Type" do
        expect(subject.build_pac(pac_opts)).to be_a(Rex::Proto::Kerberos::Pac::Type)
      end

      it "creates a PAC-TYPE with provided checksum type" do
        pac = subject.build_pac(pac_opts)
        expect(pac.checksum).to eq(Rex::Proto::Kerberos::Crypto::RSA_MD5)
      end

      it "creates a PAC-TYPE with provided data in buffers" do
        pac = subject.build_pac(pac_opts)
        expect(pac.buffers[0].effective_name).to eq('test')
      end
    end
  end

  describe "#build_pac_authorization_data" do
    context "when no opts" do
      it "creates a Rex::Proto::Kerberos::Model::AuthorizationData" do
        expect(subject.build_pac_authorization_data).to be_a(Rex::Proto::Kerberos::Model::AuthorizationData)
      end
    end

    context "when opts" do
      it "creates a Rex::Proto::Kerberos::Model::AuthorizationData" do
        pac = subject.build_pac(pac_opts)
        expect(subject.build_pac_authorization_data(pac: pac)).to be_a(Rex::Proto::Kerberos::Model::AuthorizationData)
      end
    end

    it "creates an AD_IF_RELEVANT element" do
      pac = subject.build_pac(pac_opts)
      pac_ad = subject.build_pac_authorization_data(pac: pac)

      expect(pac_ad.elements[0][:type]).to eq(Rex::Proto::Kerberos::Model::AD_IF_RELEVANT)
    end
  end

  describe "#build_pa_pac_request" do
    context "when no opts" do
      it "creates Rex::Proto::Kerberos::Model::PreAuthData" do
        expect(subject.build_pa_pac_request).to be_a(Rex::Proto::Kerberos::Model::PreAuthData)
      end

      it "creates a PA_PAC_REQUEST" do
        req = subject.build_pa_pac_request
        expect(req.type).to eq(Rex::Proto::Kerberos::Model::PA_PAC_REQUEST)
      end

      it "creates a false PA_PAC_REQUEST" do
        req = subject.build_pa_pac_request
        expect(req.value).to eq("\x30\x05\xA0\x03\x01\x01\x00")
      end
    end

    context "when opts" do
      it "creates a Rex::Proto::Kerberos::Model::PreAuthData" do
        expect(subject.build_pa_pac_request(pac_request_value: true)).to be_a(Rex::Proto::Kerberos::Model::PreAuthData)
      end

      it "creates a PA_PAC_REQUEST" do
        req = subject.build_pa_pac_request(pac_request_value: true)
        expect(req.type).to eq(Rex::Proto::Kerberos::Model::PA_PAC_REQUEST)
      end

      it "creates PA_PAC_REQUEST with opts value" do
        req = subject.build_pa_pac_request(pac_request_value: true)
        expect(req.value).to eq("\x30\x05\xA0\x03\x01\x01\xff")
      end
    end
  end
end

