// Jest setup file for navigation integration tests
// This file sets up the testing environment for DOM manipulation tests

// Mock MediaPipe and camera APIs that are not available in test environment
global.Camera = class MockCamera {
    constructor() {}
    start() { return Promise.resolve(); }
    stop() {}
};

global.Pose = class MockPose {
    constructor() {}
    setOptions() {}
    onResults() {}
    send() { return Promise.resolve(); }
};

global.drawConnectors = () => {};
global.drawLandmarks = () => {};
global.POSE_CONNECTIONS = [];

// Mock navigator.mediaDevices for camera tests
global.navigator = global.navigator || {};
Object.defineProperty(global.navigator, 'mediaDevices', {
    value: {
        getUserMedia: jest.fn(() => Promise.resolve({
            getTracks: () => [{ stop: jest.fn() }]
        }))
    },
    writable: true
});

// Suppress console warnings for missing MediaPipe resources in tests
const originalConsoleWarn = console.warn;
console.warn = (...args) => {
    if (args[0] && args[0].includes('MediaPipe')) return;
    originalConsoleWarn.apply(console, args);
};