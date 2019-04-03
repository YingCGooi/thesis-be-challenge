import React from 'react';
import { connect } from 'react-redux';

import {
  BrowserRouter as Router,
  Route,
  Link,
} from 'react-router-dom';

class App extends React.Component {
  state = {

  }
 
  render() {
    const pathname = window.location.pathname;

    return (
      <div>Hello world!</div>
    )
  }
}

const mapStateToProps = (state) => (
  {}
)

const mapDispatchToProps = (dispatch) => (
  {}
)

export default connect(mapStateToProps, mapDispatchToProps)(App);