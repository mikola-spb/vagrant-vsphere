require 'spec_helper'

CUSTOM_VM_FOLDER = 'custom_vm_folder'

describe VagrantPlugins::VSphere::Action::Clone do
  before :each do
    @env[:vSphere_connection] = @vim
  end

  it "should create a CloneVM task with template's parent" do
    call
    expect(@template).to have_received(:CloneVM_Task).with({
      :folder => @data_center,
      :name => NAME,
      :spec => {:location => {:pool => @child_resource_pool} }
    })
  end

  it 'should create a CloneVM task with custom folder when given vm base path' do
    custom_base_folder = double(CUSTOM_VM_FOLDER,
                                :pretty_path => "#{@data_center.pretty_path}/#{CUSTOM_VM_FOLDER}")
    @machine.provider_config.stub(:vm_base_path).and_return(CUSTOM_VM_FOLDER)
    @data_center.vmFolder.stub(:traverse).with(CUSTOM_VM_FOLDER, RbVmomi::VIM::Folder).and_return(custom_base_folder)
    call
    expect(@template).to have_received(:CloneVM_Task).with({
      :folder => custom_base_folder,
      :name => NAME,
      :spec => {:location => {:pool => @child_resource_pool} }
    })
  end

  it 'should set the machine id to be the new UUID' do
    call
    expect(@machine).to have_received(:id=).with(NEW_UUID)
  end

  it 'should call the next item in the middleware stack' do
    call
    expect(@app).to have_received :call
  end

  it 'should set static IP when given config spec' do
    @machine.provider_config.stub(:customization_spec_name).and_return('spec')
    call
    expect(@ip).to have_received(:ipAddress=).with('0.0.0.0')
  end

  it 'should use root resource pool when cloning from template and no resource pool specified' do
    @machine.provider_config.stub(:resource_pool_name).and_return(nil)
    call
    expect(@template).to have_received(:CloneVM_Task).with({
      :folder => @data_center,
      :name => NAME,
      :spec => {:location => {:pool => @root_resource_pool } }
    })
  end
end
