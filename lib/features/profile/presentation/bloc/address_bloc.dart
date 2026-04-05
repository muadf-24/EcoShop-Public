import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/address_repository.dart';
import 'address_event.dart';
import 'address_state.dart';

class AddressBloc extends Bloc<AddressEvent, AddressState> {
  final AddressRepository addressRepository;

  AddressBloc({required this.addressRepository}) : super(AddressInitial()) {
    on<LoadAddresses>(_onLoadAddresses);
    on<AddAddress>(_onAddAddress);
    on<UpdateAddress>(_onUpdateAddress);
    on<DeleteAddress>(_onDeleteAddress);
    on<SetDefaultAddress>(_onSetDefaultAddress);
  }

  Future<void> _onLoadAddresses(LoadAddresses event, Emitter<AddressState> emit) async {
    emit(AddressLoading());
    try {
      final addresses = await addressRepository.getAddresses();
      emit(AddressLoaded(addresses));
    } catch (e) {
      emit(AddressError(e.toString()));
    }
  }

  Future<void> _onAddAddress(AddAddress event, Emitter<AddressState> emit) async {
    emit(AddressLoading());
    try {
      await addressRepository.addAddress(event.address);
      emit(const AddressOperationSuccess('Address added successfully'));
      add(LoadAddresses());
    } catch (e) {
      emit(AddressError(e.toString()));
    }
  }

  Future<void> _onUpdateAddress(UpdateAddress event, Emitter<AddressState> emit) async {
    emit(AddressLoading());
    try {
      await addressRepository.updateAddress(event.address);
      emit(const AddressOperationSuccess('Address updated successfully'));
      add(LoadAddresses());
    } catch (e) {
      emit(AddressError(e.toString()));
    }
  }

  Future<void> _onDeleteAddress(DeleteAddress event, Emitter<AddressState> emit) async {
    emit(AddressLoading());
    try {
      await addressRepository.deleteAddress(event.addressId);
      emit(const AddressOperationSuccess('Address deleted successfully'));
      add(LoadAddresses());
    } catch (e) {
      emit(AddressError(e.toString()));
    }
  }

  Future<void> _onSetDefaultAddress(SetDefaultAddress event, Emitter<AddressState> emit) async {
    emit(AddressLoading());
    try {
      await addressRepository.setDefaultAddress(event.addressId);
      emit(const AddressOperationSuccess('Default address updated'));
      add(LoadAddresses());
    } catch (e) {
      emit(AddressError(e.toString()));
    }
  }
}
