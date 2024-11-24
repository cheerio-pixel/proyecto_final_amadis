// src/app/pages/news/news.page.ts
import { Component, OnInit, ViewChild } from '@angular/core';
import { IonContent, IonRefresher, LoadingController } from '@ionic/angular';
import { NewsService, NewsItem } from '../../services/news.service';
import { finalize } from 'rxjs/operators';

@Component({
  selector: 'app-news',
  templateUrl: './news.page.html',
  styleUrls: ['./news.page.scss']
})
export class NewsPage implements OnInit {
  @ViewChild(IonContent) content!: IonContent;
  news: NewsItem[] = [];
  isLoading = false;
  error: string | null = null;
  selectedCategory: string = 'all';
  categories: string[] = ['all', 'académico', 'cultura', 'deportes', 'investigación'];

  constructor(
    private newsService: NewsService,
    private loadingController: LoadingController
  ) {}

  ngOnInit() {
    this.loadNews();
  }

  async loadNews(event?: any) {
    if (!event) {
      const loading = await this.loadingController.create({
        message: 'Cargando noticias...',
        spinner: 'crescent'
      });
      await loading.present();
      this.isLoading = true;
    }

    this.newsService.fetchNews(!!event).pipe(
      finalize(() => {
        this.isLoading = false;
        if (event) {
          event.target.complete();
        } else {
          this.loadingController.dismiss();
        }
      })
    ).subscribe({
      next: (news) => {
        this.news = news;
        this.error = null;
      },
      error: (error) => {
        this.error = 'No se pudieron cargar las noticias. Por favor, intente nuevamente.';
        console.error('Error loading news:', error);
      }
    });
  }

  async doRefresh(event: any) {
    await this.loadNews(event);
  }

  filterNewsByCategory(category: string) {
    this.selectedCategory = category;
    this.content.scrollToTop();
  }

  getFilteredNews(): NewsItem[] {
    if (this.selectedCategory === 'all') {
      return this.news;
    }
    return this.news.filter(item => item.category?.toLowerCase() === this.selectedCategory);
  }

  formatDate(dateString: string): string {
    const date = new Date(dateString);
    return new Intl.DateTimeFormat('es-DO', {
      year: 'numeric',
      month: 'long',
      day: 'numeric',
      hour: '2-digit',
      minute: '2-digit'
    }).format(date);
  }
}
