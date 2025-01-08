<?php

namespace App\Http\Controllers;

use App\Models\User;

class TestController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index()
    {
        $users = User::all();
        return response()->json($users);
    }
}
