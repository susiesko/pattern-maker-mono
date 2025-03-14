import '@testing-library/jest-dom'

// Mock for IntersectionObserver
class IntersectionObserverMock {
  readonly root: Element | null = null;
  readonly rootMargin: string = '';
  readonly thresholds: ReadonlyArray<number> = [];

  constructor() {
    this.observe = vi.fn();
    this.unobserve = vi.fn();
    this.disconnect = vi.fn();
  }

  observe = vi.fn();
  unobserve = vi.fn();
  disconnect = vi.fn();
}

// Set up global mocks
beforeAll(() => {
  // Mock IntersectionObserver
  window.IntersectionObserver = IntersectionObserverMock;
  
  // Mock fetch
  global.fetch = vi.fn();
});