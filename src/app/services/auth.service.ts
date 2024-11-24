// src/app/services/auth.service.ts
import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable, BehaviorSubject, firstValueFrom } from 'rxjs';
import { tap } from 'rxjs/operators';
import { environment } from '../../environments/environment';
import { Router } from '@angular/router';

interface LoginCredentials {
  username: string;
  password: string;
}

interface PasswordResetRequest {
  usuario: string;
  email: string;
}

interface PasswordChangeRequest {
  oldPassword: string;
  newPassword: string;
  confirmPassword: string;
}

@Injectable({
  providedIn: 'root'
})
export class AuthService {
  private readonly TOKEN_KEY = 'auth_token';
  private authSubject = new BehaviorSubject<boolean>(false);
  public isAuthenticated$ = this.authSubject.asObservable();
  
  constructor(
    private http: HttpClient,
    private router: Router
  ) {
    // Initialize auth state based on token presence
    this.authSubject.next(this.hasValidToken());
  }

  private hasValidToken(): boolean {
    return !!this.getAuthToken();
  }

  getAuthToken(): string | null {
    return localStorage.getItem(this.TOKEN_KEY);
  }

  private setAuthToken(token: string): void {
    localStorage.setItem(this.TOKEN_KEY, token);
  }

  private removeAuthToken(): void {
    localStorage.removeItem(this.TOKEN_KEY);
  }

  login(credentials: LoginCredentials): Observable<any> {
    return this.http.post(`${environment.apiUrl}/login`, credentials)
      .pipe(
        tap((response: any) => {
          if (response.authToken) {
            this.setAuthToken(response.authToken);
            this.authSubject.next(true);
          }
        })
      );
  }

  async loginAsync(credentials: LoginCredentials): Promise<any> {
    const response = await firstValueFrom(this.login(credentials));
    return response;
  }

  async requestPasswordReset(formData: PasswordResetRequest): Promise<any> {
    return firstValueFrom(
      this.http.post(`${environment.apiUrl}/reset_password`, formData)
    );
  }

  async changePassword(passwordData: PasswordChangeRequest): Promise<any> {
    return firstValueFrom(
      this.http.post(`${environment.apiUrl}/cambiar_password`, passwordData)
    );
  }

  logout(): void {
    this.removeAuthToken();
    this.authSubject.next(false);
    this.router.navigate(['/login']);
  }

  isAuthenticated(): boolean {
      return (!!this.authSubject.value) && this.checkTokenExpiration(this.getAuthToken()!);
  }
private checkTokenExpiration(token: string): boolean {
    try {
      const tokenData = JSON.parse(atob(token.split('.')[1]));
      const expirationDate = new Date(tokenData.exp * 1000);
      return new Date() < expirationDate;
    } catch {
      return false;
    }
  }
}
