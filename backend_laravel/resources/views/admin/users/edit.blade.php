@extends('admin.layouts.app')

@section('title', 'Edit Pengguna')

@section('content')
    <div class="card">
        <div class="card-body">
            <form method="POST" action="{{ route('admin.users.update', $user) }}">
                @csrf @method('PUT')
                @include('admin.users._form')
            </form>
        </div>
    </div>
@endsection
