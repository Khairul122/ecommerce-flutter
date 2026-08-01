@extends('admin.layouts.app')

@section('title', 'Tambah Pengguna')

@section('content')
    <div class="card">
        <div class="card-body">
            <form method="POST" action="{{ route('admin.users.store') }}">
                @csrf
                @include('admin.users._form')
            </form>
        </div>
    </div>
@endsection
