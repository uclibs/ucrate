# frozen_string_literal: true
require 'spec_helper'

describe Hydra::AccessControls::Permission do
  describe "an initialized instance" do
    let(:permission) { described_class.new(type: 'person', name: 'bob', access: 'read') }

    it "sets predicates" do
      expect(permission.agent.first.rdf_subject).to eq ::RDF::URI.new('http://projecthydra.org/ns/auth/person#bob')
      expect(permission.mode.first.rdf_subject).to eq ACL.Read
    end

    describe "#to_hash" do
      subject { permission.to_hash }
      it { is_expected.to eq(type: 'person', name: 'bob', access: 'read') }
    end

    describe "#agent_name" do
      subject { permission.agent_name }
      it { is_expected.to eq 'bob' }
    end

    describe "#access" do
      subject { permission.access }
      it { is_expected.to eq 'read' }
    end

    describe "#type" do
      subject { permission.type }
      it { is_expected.to eq 'person' }
    end
  end

  describe "equality comparison" do
    let(:perm1) { described_class.new(type: 'person', name: 'bob', access: 'read') }
    let(:perm2) { described_class.new(type: 'person', name: 'bob', access: 'read') }
    let(:perm3) { described_class.new(type: 'person', name: 'jane', access: 'read') }

    it "is equal if all values are equal" do
      expect(perm1).to eq perm2
    end

    it "is unequal if some values are unequal" do
      expect(perm1).not_to eq perm3
      expect(perm2).not_to eq perm3
    end
  end

  describe "URI escaping" do
    let(:user_permission) { described_class.new(type: 'person', name: 'john doe', access: 'read') }
    let(:user_permission2) { described_class.new(type: 'person', name: 'john%20doe', access: 'read') }
    let(:user_permission3) { described_class.new(type: 'person', name: 'john+doe', access: 'read') }
    let(:group_permission) { described_class.new(type: 'group', name: 'hydra devs', access: 'read') }
    let(:group_permission2) { described_class.new(type: 'group', name: 'hydra%20devs', access: 'read') }
    let(:group_permission3) { described_class.new(type: 'group', name: 'hydra+devs', access: 'read') }

    it "escapes agent when building" do
      expect(user_permission.agent.first.rdf_subject.to_s).to eq 'http://projecthydra.org/ns/auth/person#john%20doe'
      expect(user_permission2.agent.first.rdf_subject.to_s).to eq 'http://projecthydra.org/ns/auth/person#john%2520doe'
      expect(user_permission3.agent.first.rdf_subject.to_s).to eq 'http://projecthydra.org/ns/auth/person#john+doe'
      expect(group_permission.agent.first.rdf_subject.to_s).to eq 'http://projecthydra.org/ns/auth/group#hydra%20devs'
      expect(group_permission2.agent.first.rdf_subject.to_s).to eq 'http://projecthydra.org/ns/auth/group#hydra%2520devs'
      expect(group_permission3.agent.first.rdf_subject.to_s).to eq 'http://projecthydra.org/ns/auth/group#hydra+devs'
    end

    it "unescapes agent when parsing" do
      expect(user_permission.agent_name).to eq 'john doe'
      expect(user_permission2.agent_name).to eq 'john%20doe'
      expect(user_permission3.agent_name).to eq 'john+doe'
      expect(group_permission.agent_name).to eq 'hydra devs'
      expect(group_permission2.agent_name).to eq 'hydra%20devs'
      expect(group_permission3.agent_name).to eq 'hydra+devs'
    end

    context 'with a User instance passed as :name argument' do
      let(:permission) { described_class.new(type: 'person', name: user, access: 'read') }
      let(:user) { FactoryBot.build(:archivist, email: 'archivist1@example.com') }

      it "uses string and escape agent when building" do
        expect(permission.agent.first.rdf_subject.to_s).to eq 'http://projecthydra.org/ns/auth/person#archivist1@example.com'
      end
    end
  end
end
