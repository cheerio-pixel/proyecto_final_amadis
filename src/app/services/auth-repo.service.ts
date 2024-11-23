import { Injectable } from '@angular/core';

@Injectable({
  providedIn: 'root'
})
export class AuthRepoService {

  constructor() { }

    setAuthToken(token: string) {
        localStorage.setItem('auth_token', token);
    }

    removeAuthToken(): void {
    localStorage.removeItem('auth_token');
    }

  getAuthToken(): string | null {
    return localStorage.getItem('auth_token');
  }
}
