<?php

namespace App\Http\Controllers;

class TestController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index()
    {
        $message = "Hello World";
        return response()->json($message);
    }
}
