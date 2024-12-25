<?php

namespace App\Http\Controllers;


class TestController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index()
    {
        $placeholderUsers = [
            [
                'id' => 1,
                'name' => 'John Doe',
                'email' => 'example@email.com',
            ],
            [
                'id' => 2,
                'name' => 'Jane Doe',
                'email' => 'example2@email.com',
            ],
            [
                'id' => 3,
                'name' => 'John Smith',
                'email' => 'example3@email.com',
            ],
        ];

        return response()->json($placeholderUsers);
    }
}
