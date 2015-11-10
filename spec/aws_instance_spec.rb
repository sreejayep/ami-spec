require 'spec_helper'

describe AmiSpec::AwsInstance do
  let(:role) { 'web_server' }
  let(:options) { {} }
  let(:client_double) { instance_double(Aws::EC2::Client) }
  let(:ec2_double) { instance_double(Aws::EC2::Types::Instance) }
  subject(:instance) do
    described_class.new(
      role: role,
      ami: 'ami',
      subnet_id: 'subnet',
      key_name: 'key',
      options: options
    )
  end

  before do
    allow(Aws::EC2::Client).to receive(:new).and_return(client_double)
    allow(client_double).to receive(:run_instances).and_return(double(instances: [ec2_double]))
    allow(client_double).to receive(:create_tags).and_return(double)
    allow(ec2_double).to receive(:instance_id)
  end

  describe '#start' do
    subject(:start) { instance.start }
    context 'with no options' do
      it 'does not include optional parameters' do
        expect(client_double).to receive(:run_instances).with(
                                   hash_excluding(:region, :security_group_ids)
                                 )
        start
      end
    end

    context 'with options' do
      let(:options) { {region: 'us-east-1', security_group_ids: '1234'}}

      it 'does include options' do
        expect(client_double).to receive(:run_instances).with(
                                   hash_including(:region, :security_group_ids)
                                 )
        start
      end
    end

    it 'tags the instance with a role' do
      expect(client_double).to receive(:create_tags).with(
                                 hash_including(tags: [{ key: 'AmiSpec', value: role}])
                               )
      start
    end

  end
end